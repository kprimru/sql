USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[ResVersion@Check]', 'TF') IS NULL EXEC('CREATE FUNCTION [USR].[ResVersion@Check] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO
CREATE FUNCTION [Usr].[ResVersion@Check]
(
	@MANAGER	INT,
	@SERVICE	INT,
	@DATE		SMALLDATETIME,
	@STATUS		VARCHAR(MAX),
	@ACTUAL		BIT,
	@CUSTOM		BIT,
	@RLIST		VARCHAR(MAX),
	@CLIST		VARCHAR(MAX),
	@KLIST		VARCHAR(MAX)
)
RETURNS @TBL TABLE
(
	ClientID			Int,
	ClientFullName		VarChar(512),
	ManagerName			VarChar(128),
	ServiceName			VarChar(128),
	Complect			VarChar(128),
	ResVersionNumber	VarChar(128),
	ConsExeVersionName	VarChar(128),
	KDVersionName		VarChar(128),
	UF_DATE				DateTime,
	UF_CREATE			DateTime
)
AS
BEGIN
	DECLARE @Statuses Table(ST_ID Int);
	DECLARE @Clients Table(CL_ID Int);
	DECLARE @Res Table(RES_ID Int);
	DECLARE @Cons Table(CONS_ID Int);
	DECLARE @Kd Table(KD_ID UniqueIdentifier);

	IF @STATUS IS NOT NULL
		INSERT INTO @Statuses(ST_ID)
		SELECT ID
		FROM dbo.TableIDFromXML(@STATUS);
	ELSE
		INSERT INTO @Statuses(ST_ID)
		SELECT 2;


	INSERT INTO @Clients(CL_ID)
	SELECT ClientID
	FROM dbo.ClientView WITH(NOEXPAND)
	INNER JOIN @Statuses ON ST_ID = ServiceStatusID
	WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
		AND (ManagerID = @MANAGER OR @MANAGER IS NULL);

	IF @ACTUAL = 1
	BEGIN
		INSERT INTO @res(RES_ID)
		SELECT ResVersionID
		FROM dbo.ResVersionTable
		WHERE IsLatest = 1;

		INSERT INTO @Cons(CONS_ID)
		SELECT ConsExeVersionID
		FROM dbo.ConsExeVersionTable
		WHERE ConsExeVersionActive = 1;

		INSERT INTO @Kd(KD_ID)
		SELECT ID
		FROM dbo.KDVersion
		WHERE ACTIVE = 1;
	END
	ELSE IF @CUSTOM = 1
	BEGIN
		INSERT INTO @Res(RES_ID)
		SELECT ID
		FROM dbo.TableIDFromXML(@RLIST);

		INSERT INTO @Cons(CONS_ID)
		SELECT ID
		FROM dbo.TableIDFromXML(@CLIST);

		INSERT INTO @Kd(KD_ID)
		SELECT ID
		FROM dbo.TableGUIDFromXML(@KLIST);
	END;

	INSERT INTO @TBL
	SELECT
		ClientID, ClientFullName, ManagerName, ServiceName, rnsw.Complect,
		CASE WHEN RES_ID IS NULL THEN ResVersionShort ELSE '' END AS ResVersionNumber,
		CASE WHEN CONS_ID IS NULL THEN ConsExeVersionName ELSE '' END AS ConsExeVersionName,
		/*CASE WHEN KD_ID IS NULL THEN SHORT ELSE '' END */ '' AS KDVersionName,
		UF_DATE, UF_CREATE
	FROM
		USR.USRComplectCurrentStatusView a WITH(NOEXPAND)
		INNER JOIN dbo.SystemTable AS s ON a.UD_SYS = s.SystemNumber
		INNER JOIN Reg.RegNodeSearchView rnsw WITH(NOEXPAND) ON a.UD_DISTR = rnsw.DistrNumber AND a.UD_COMP = rnsw.CompNumber AND s.SystemId = rnsw.SystemID AND rnsw.DS_REG = 0
		INNER JOIN USR.USRActiveView b ON a.UD_ID = b.UD_ID
		INNER JOIN USR.USRFileTech t ON b.UF_ID = t.UF_ID
		INNER JOIN @Clients c ON c.CL_ID = b.UD_ID_CLIENT
		INNER JOIN dbo.ClientView d WITH(NOEXPAND) ON c.CL_ID = d.ClientID
		INNER JOIN dbo.ResVersionTable e ON e.ResVersionID = t.UF_ID_RES
		INNER JOIN dbo.ConsExeVersionTable f ON t.UF_ID_CONS = ConsExeVersionID
		LEFT OUTER JOIN dbo.KDVersion g ON t.UF_ID_KDVERSION = g.ID
		LEFT OUTER JOIN @Res ON RES_ID = t.UF_ID_RES
		LEFT OUTER JOIN @Cons ON CONS_ID = t.UF_ID_CONS
		LEFT OUTER JOIN @Kd ON KD_ID = t.UF_ID_KDVERSION
	WHERE UD_SERVICE = 0
		AND (UF_DATE >= @DATE OR @DATE IS NULL)
		AND (RES_ID IS NULL OR CONS_ID IS NULL /*OR KD_ID IS NULL*/)
	ORDER BY ManagerName, ServiceName, ClientFullName, UD_NAME;

	RETURN;
END
GO
