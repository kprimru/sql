USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ONLINE_ACTIVITY_LOAD]
	@YEAR		INT,
	@WEEK_NUM	INT,
	@LOGIN		NVARCHAR(256),
	@ACTIVITY	BIT = NULL,
	@LOGIN_CNT	SMALLINT = NULL,
	@SESSION_TIME SMALLINT = NULL
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

		DECLARE @ID_WEEK UNIQUEIDENTIFIER

		SELECT @ID_WEEK = ID
		FROM Common.Period
		WHERE TYPE = 1
			AND DATEPART(YEAR, FINISH) = @YEAR
			--AND (DATEPART(WEEK, FINISH) = @WEEK_NUM OR DATEPART(WEEK, START) = @WEEK_NUM)
			--AND dbo.ISO_WEEK(FINISH) = @WEEK_NUM OR dbo.ISO_WEEK(START) = @WEEK_NUM
			AND dbo.ISO_WEEK(START) = @WEEK_NUM

		IF @ID_WEEK IS NULL
			SELECT @ID_WEEK = ID
			FROM Common.Period
			WHERE TYPE = 1
				AND DATEPART(YEAR, START) = @YEAR
				--AND (DATEPART(WEEK, FINISH) = @WEEK_NUM OR DATEPART(WEEK, START) = @WEEK_NUM)
				--AND dbo.ISO_WEEK(FINISH) = @WEEK_NUM OR dbo.ISO_WEEK(START) = @WEEK_NUM
				AND dbo.ISO_WEEK(START) = @WEEK_NUM

		IF @ID_WEEK IS NULL
		BEGIN
			DECLARE @S NVARCHAR(512)
			SET @S = '�� ������� ���������� ����� ������. ���: ' + CONVERT(NVARCHAR(16), @YEAR) + '. ������: ' + CONVERT(NVARCHAR(16), @WEEK_NUM)
			RAISERROR(@S, 16, 1)
		END

		DECLARE	@HOST	INT
		DECLARE @DISTR	INT
		DECLARE @COMP	TINYINT

		DECLARE @DIS_STR	NVARCHAR(256)


		IF CHARINDEX('#', @LOGIN) = 0
			SET @DIS_STR = @LOGIN
		ELSE
			SET @DIS_STR = LEFT(@LOGIN, CHARINDEX('#', @LOGIN) - 1)

		IF CHARINDEX('_', @DIS_STR) = 0
		BEGIN
			SET @DISTR = CONVERT(INT, @DIS_STR)
			SET @COMP = 1
		END
		ELSE
		BEGIN
			SET @DISTR = CONVERT(INT, LEFT(@DIS_STR, CHARINDEX('_', @DIS_STR) - 1))
			SET @COMP = CONVERT(TINYINT, RIGHT(@DIS_STR, LEN(@DIS_STR) - CHARINDEX('_', @DIS_STR)))
		END

		SELECT @HOST = HostID
		FROM dbo.Hosts
		WHERE HostReg = 'LAW'

		IF @LOGIN_CNT > 0
			SET @ACTIVITY = 1
		ELSE IF @LOGIN_CNT = 0
			SET @ACTIVITY = 0;

		INSERT INTO dbo.OnlineActivity(ID_WEEK, ID_HOST, DISTR, COMP, LGN, ACTIVITY, LOGIN_CNT, SESSION_TIME)
			SELECT @ID_WEEK, @HOST, @DISTR, @COMP, @LOGIN, @ACTIVITY, @LOGIN_CNT, @SESSION_TIME
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.OnlineActivity
					WHERE ID_WEEK = @ID_WEEK
						AND ID_HOST = @HOST
						AND DISTR = @DISTR
						AND COMP = @COMP
						AND LGN = @LOGIN
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ONLINE_ACTIVITY_LOAD] TO rl_import_data;
GO
