USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[COMPLECT_REG_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[COMPLECT_REG_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [USR].[COMPLECT_REG_SELECT]
	@CL_ID	INT,
	@BEGIN	SMALLDATETIME = NULL,
	@END	SMALLDATETIME = NULL,
	@ACTIVE	BIT	= 1
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

		IF @BEGIN IS NULL
			SET @BEGIN = DATEADD(MONTH, -2, GETDATE())

		DECLARE @UD	TABLE(CPL INT)

		INSERT INTO @UD
		SELECT DISTINCT UD_ID
		FROM 
			Reg.RegNodeSearchView r WITH(NOEXPAND)
			INNER JOIN USR.USRData d ON d.UD_ID_HOST = r.HostId
									AND d.UD_DISTR = r.DistrNumber
									AND d.UD_COMP = r.CompNumber
		WHERE r.ID = @CL_ID

		DECLARE @CPL TABLE
			(
				UD_ID					INT,
				UF_ID					INT,
				UD_NAME					VARCHAR(50),
				UD_ACTIVE				BIT,
				UF_ID_MASTER			INT,
				UF_DATE					DATETIME,
				USRFileKindShortName	VARCHAR(100),
				UF_UPTIME				VARCHAR(50),
				UF_ACTIVE				BIT,
				UF_PATH					VARCHAR(20),
				UF_CREATE				DATETIME
			)

		INSERT INTO @CPL(UD_ID, UF_ID, UD_NAME, UD_ACTIVE, UF_DATE, USRFileKindShortName, UF_UPTIME, UF_ACTIVE, UF_PATH, UF_CREATE)
		SELECT
			UD_ID, UF_ID, dbo.DistrString(SystemShortName, UD_DISTR, UD_COMP), UD_ACTIVE, UF_DATE, USRFileKindShortName, UF_UPTIME, UF_ACTIVE,
			CASE UF_PATH
				WHEN 1 THEN 'РОБОТ'
				WHEN 2 THEN 'ИП'
				WHEN 3 THEN 'КОНТРОЛЬ'
				ELSE ''
			END AS UF_PATH,
			UF_CREATE
		FROM USR.USRData
		INNER JOIN @UD ON CPL = UD_ID
		CROSS APPLY
		(
			SELECT TOP 1 UF_ID, UF_UPTIME, UF_DATE, UF_ACTIVE, UF_PATH, UF_CREATE, SystemShortName, USRFileKindShortName
			FROM USR.USRFile F
			INNER JOIN dbo.SystemTable S ON F.UF_ID_SYSTEM = S.SystemId
			INNER JOIN dbo.USRFileKindTable ON USRFileKindID = UF_ID_KIND
			WHERE UF_ID_COMPLECT = UD_ID
			ORDER BY UF_DATE DESC
		) AS F
		WHERE UD_ACTIVE =
				CASE @ACTIVE
					WHEN 0 THEN 1
					ELSE UD_ACTIVE
				END

		IF @BEGIN IS NULL AND @END IS NULL
		BEGIN
			SELECT @BEGIN = UF_DATE
			FROM @CPL

			SET @BEGIN = DATEADD(MONTH, -2, @BEGIN)
		END

		IF @END IS NOT NULL
			SET @END = DATEADD(DAY, 1, @END)

		INSERT INTO @CPL(UD_ID, UF_ID, UD_NAME, UD_ACTIVE, UF_ID_MASTER, UF_DATE, USRFileKindShortName, UF_UPTIME, UF_ACTIVE, UF_PATH, UF_CREATE)
			SELECT
				a.UD_ID, b.UF_ID, dbo.DistrString(SystemShortName, UD_DISTR, UD_COMP), a.UD_ACTIVE,
				c.UF_ID, b.UF_DATE, d.USRFileKindShortName, b.UF_UPTIME, b.UF_ACTIVE,
				CASE b.UF_PATH
					WHEN 1 THEN 'РОБОТ'
					WHEN 2 THEN 'ИП'
					WHEN 3 THEN 'КОНТРОЛЬ'
					ELSE ''
				END AS UF_PATH,
				b.UF_CREATE
			FROM
				USR.USRData a
				INNER JOIN @UD ON CPL = UD_ID
				INNER JOIN USR.USRFile b ON UF_ID_COMPLECT = UD_ID
				INNER JOIN dbo.USRFileKindTable d ON USRFileKindID = UF_ID_KIND
				INNER JOIN dbo.SystemTable s ON s.SystemID = b.UF_ID_SYSTEM
				INNER JOIN @CPL c ON c.UD_ID = a.UD_ID AND UF_ID_MASTER IS NULL
			WHERE a.UD_ACTIVE =
					CASE @ACTIVE
						WHEN 0 THEN 1
						ELSE a.UD_ACTIVE
					END
				AND (b.UF_DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (b.UF_DATE < @END OR @END IS NULL)
				AND NOT EXISTS
					(
						SELECT *
						FROM @CPL d
						WHERE d.UF_ID = b.UF_ID
					)

		SELECT
			UD_ID, UF_ID,
			UF_ID_MASTER,
			UD_NAME, UD_ACTIVE, UF_DATE, UF_UPTIME, USRFileKindShortName, UF_ACTIVE,
			UF_PATH, UF_CREATE,
			CASE

				WHEN EXISTS
					(
						SELECT *
						FROM
							USR.USRIB INNER JOIN
							dbo.ComplianceTypeTable ON ComplianceTypeID = UI_ID_COMP
						WHERE UI_ID_USR = UF_ID
							AND ComplianceTypeName = '#HOST'
					) THEN 1

				ELSE 3
			END AS UF_CORRECT
		FROM @CPL
		ORDER BY UF_ID_MASTER, UF_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [USR].[COMPLECT_REG_SELECT] TO rl_tech_reg;
GO
