USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[CLIENT_SYSTEM_AUDIT]
	@MANAGER	INT = NULL,
	@SERVICE	INT = NULL,
	@IB			NVARCHAR(MAX) = NULL,
	@DATE		SMALLDATETIME = NULL,
	@CLIENT		INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Clients Table
	(
		ClientId		Int				NOT NULL,
		Primary Key Clustered(ClientId)
	);
	
	DECLARE @ClientsComplects Table
	(
		ClientId		Int				NOT NULL,
		Complect		VarChar(100)	NOT NULL,
		UF_ID			Int					NULL,
		UF_DATE			SmallDateTime		NULL,
		InfoBanks		VarChar(Max)		NULL,
		InfoBanksCodes	VarChar(Max)		NULL,
		Primary Key Clustered(ClientId, Complect)
	);

	DECLARE @IBOut Table
	(
		Complect		VarChar(100)	NOT NULL,
		InfoBankId		SmallInt		NOT NULL,
		Primary Key Clustered(Complect, InfoBankId)
	);

	DECLARE @InfoBanks Table
	(
		Id				SmallInt		NOT NULL PRIMARY KEY CLUSTERED
	);
	
	IF @IB IS NOT NULL
		INSERT INTO @InfoBanks
		SELECT DISTINCT ID
		FROM dbo.TableIDFromXML(@IB);

	INSERT INTO @Clients
	SELECT ClientId
	FROM dbo.ClientView a WITH(NOEXPAND)
	INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
	WHERE	(ServiceId = @SERVICE	OR @SERVICE IS NULL)
		AND (ManagerId = @Manager	OR @MANAGER IS NULL)
		AND (ClientId = @CLIENT		OR @CLIENT IS NULL);


	INSERT INTO @ClientsComplects(ClientId, Complect, UF_ID, UF_DATE)
	SELECT DISTINCT C.ClientId, R.Complect, U.UF_ID, U.UF_DATE
	FROM @Clients							C
	INNER JOIN dbo.ClientDistrView			D WITH(NOEXPAND)	ON	D.ID_CLIENT = C.ClientId
	INNER JOIN dbo.RegNodeMainSystemView	R WITH(NOEXPAND)	ON	D.DISTR = R.DistrNumber
																AND D.COMP = R.CompNumber
	INNER JOIN dbo.SystemTable				S					ON	S.SystemBaseName = R.SystemBaseName
																AND D.HostID = S.HostId
	OUTER APPLY
	(
		SELECT TOP (1) UF_ID, UF_DATE
		FROM USR.USRActiveView			U
		WHERE	U.UD_DISTR = R.MainDistrNumber
			AND	U.UD_COMP = R.MainCompNumber
			AND U.UD_ID_HOST = R.MainHostID
		ORDER BY UF_DATE DESC
	) U
	WHERE	R.Service = 0
		AND	(U.UF_DATE >= @DATE OR @DATE IS NULL);
	
	-- ToDO убрать задвоение!!!	
	UPDATE C
	SET InfoBanks		= I.InfoBankName,
		InfoBanksCodes	= IC.InfoBanksCodes
	FROM @ClientsComplects					C
	CROSS APPLY
	(
		SELECT [InfoBankName] = REVERSE(STUFF(REVERSE(
			(
				SELECT
					I.InfoBankShortName + ','
				FROM dbo.ComplectInfoBankCache	CC
				INNER JOIN dbo.InfoBankTable	I	ON I.InfoBankID = CC.InfoBankID
				WHERE C.Complect = CC.Complect
					AND (@IB IS NULL OR I.InfoBankId IN (SELECT Id FROM @InfoBanks))
					AND NOT EXISTS
						(
							SELECT *
							FROM USR.USRIB I
							WHERE	I.UI_ID_USR = C.UF_ID
								AND I.UI_ID_BASE = CC.InfoBankId
						)
				ORDER BY InfoBankOrder FOR XML PATH('')
			)), 1, 1, ''))
	) I
	CROSS APPLY
	(
		SELECT [InfoBanksCodes] = REVERSE(STUFF(REVERSE(
			(
				SELECT
					I.InfoBankName + ','
				FROM dbo.ComplectInfoBankCache	CC
				INNER JOIN dbo.InfoBankTable	I	ON I.InfoBankID = CC.InfoBankID
				WHERE C.Complect = CC.Complect
					AND (@IB IS NULL OR I.InfoBankId IN (SELECT Id FROM @InfoBanks))
					AND NOT EXISTS
						(
							SELECT *
							FROM USR.USRIB I
							WHERE	I.UI_ID_USR = C.UF_ID
								AND I.UI_ID_BASE = CC.InfoBankId
						)
				ORDER BY InfoBankOrder FOR XML PATH('')
			)), 1, 1, ''))
	) IC
	OPTION(RECOMPILE);

	SELECT
		C.ClientID, CC.Complect, C.ManagerName, C.ServiceName, C.ClientFullName, CC.Complect, Banks = CC.InfoBanks, BanksEn = CC.InfoBanksCodes, LAST_DATE = NULL, CC.UF_DATE
	FROM @ClientsComplects		CC
	INNER JOIN dbo.ClientView	C	WITH(NOEXPAND)	ON C.ClientID = CC.ClientID
	WHERE CC.InfoBanks IS NOT NULL
	ORDER BY ManagerName, ServiceName, ClientFullName, CC.Complect
END

