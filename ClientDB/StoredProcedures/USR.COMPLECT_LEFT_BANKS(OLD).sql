USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[COMPLECT_LEFT_BANKS(OLD)]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[COMPLECT_LEFT_BANKS(OLD)]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[COMPLECT_LEFT_BANKS(OLD)]
	@MANAGER	INT = NULL,
	@SERVICE	INT = NULL,
	@IB			NVARCHAR(MAX) = NULL,
	@DATE		SMALLDATETIME = NULL,
	@CLIENT		INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @out_ib	TABLE
				(
					ID					INT,
					Complect			VARCHAR(30),
					InfoBankName		VARCHAR(MAX),
					InfoBankShortName	VARCHAR(MAX),
					PRIMARY KEY CLUSTERED(ID, Complect)
				)

		DECLARE @res	TABLE
				(
					ClientFullName	VARCHAR(MAX),
					Complect		VARCHAR(MAX),
					ServiceName		VARCHAR(MAX),
					ManagerName		VARCHAR(MAX),
					Banks			NVARCHAR(MAX),
					RusBanks		NVARCHAR(MAX),
					UF_DATE			DATETIME
				)

		INSERT INTO @out_ib
		SELECT ID, Complect, ibt1.InfoBankName, InfoBankShortName
		FROM dbo.ComplectInfoBankCache cib
		INNER JOIN dbo.InfoBankTable ibt1 ON ibt1.InfoBankName = cib.InfoBankName
		WHERE NOT EXISTS
			(
				SELECT Complect, ibt.InfoBankID, InfoBankName
				FROM USR.USRIB uib
				INNER JOIN USR.USRActiveView uav ON uav.UF_ID = uib.UI_ID_USR
				INNER JOIN USR.USRData ud ON ud.UD_ID = uav.UD_ID
				INNER JOIN Reg.RegNodeSearchView rns WITH(NOEXPAND) ON rns.DistrNumber = ud.UD_DISTR AND rns.HostID = ud.UD_ID_HOST AND rns.CompNumber = ud.UD_COMP
				INNER JOIN InfoBankTable ibt ON ibt.InfoBankID = uib.UI_ID_BASE
				WHERE cib.Complect = rns.Complect AND cib.InfoBankID = ibt.InfoBankID AND DS_REG = 0 AND SubhostName NOT IN ('Ó1', 'Í1', 'Ì', 'Ë1')
			)


		INSERT INTO @res
		SELECT
			cv.ClientFullName, res.Complect, cv.ServiceName, cv.ManagerName,
			REVERSE(STUFF(REVERSE((
				SELECT InfoBankName + ', '
				FROM @out_ib res2
				WHERE res.Complect = Res2.Complect
				FOR XML PATH('')
				)), 1, 2, '')) AS Banks,
			REVERSE(STUFF(REVERSE((
				SELECT InfoBankShortName + ', '
				FROM @out_ib res2
				WHERE res.Complect = Res2.Complect
				FOR XML PATH('')
				)), 1, 2, '')) AS RusBanks,
			av.UF_DATE
		FROM
			@out_ib res
		INNER JOIN Reg.RegNodeSearchView rns WITH(NOEXPAND) ON rns.Complect = res.Complect
		INNER JOIN dbo.ClientDistrView cdv WITH(NOEXPAND) ON rns.DistrNumber = cdv.DISTR AND rns.CompNumber = cdv.COMP AND rns.HostID = cdv.HostID
		INNER JOIN dbo.ClientView cv WITH(NOEXPAND) ON cv.ClientID = cdv.ID_CLIENT
		INNER JOIN USR.USRActiveView av ON av.UD_DISTR = rns.DistrNumber AND av.UD_COMP = rns.CompNumber

		WHERE
				(@MANAGER IS NULL OR cv.ManagerID = @MANAGER) AND
				(@SERVICE IS NULL OR cv.ServiceID = @SERVICE) AND
				(@DATE IS NULL OR av.UF_DATE >= @DATE) AND
				(@CLIENT IS NULL OR cdv.ID_CLIENT = @CLIENT)
		GROUP BY cv.ClientFullName, res.Complect, cv.ServiceName, cv.ManagerName, av.UF_DATE
		ORDER BY res.Complect


		DECLARE @IBNAME	VARCHAR(10)
		IF @IB IS NOT NULL
			SELECT @IBNAME = InfoBankName
			FROM dbo.InfoBankTable
			WHERE InfoBankID = @IB


		print @IBNAME

		SELECT *
		FROM @res
		WHERE
			@IB IS NULL OR (Banks LIKE '%, '+@IBNAME +', %') OR (Banks LIKE @IBNAME +', %') OR (Banks LIKE '%, '+@IBNAME)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[COMPLECT_LEFT_BANKS(OLD)] TO rl_complect_info_bank;
GO
