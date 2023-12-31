USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[RISK_SAVE]
	@SEARCH_MON		SMALLINT,
	@SEARCH_CNT		SMALLINT,
	@DUTY_MON		SMALLINT,
	@DUTY_CNT		SMALLINT,
	@RIVAL_MON		SMALLINT,
	@RIVAL_CNT		SMALLINT,
	@UPD_WEEK		SMALLINT,
	@UPD_CNT		SMALLINT,
	@STUDY_MON		SMALLINT,
	@STUDY_CNT		SMALLINT,
	@SEMINAR_MON	SMALLINT,
	@SEMINAR_CNT	SMALLINT
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

		IF NOT EXISTS
			(
				SELECT *
				FROM dbo.Risk
				WHERE STATUS = 1
			)
		BEGIN
			INSERT INTO dbo.Risk(SEARCH_MON, SEARCH_CNT, DUTY_MON, DUTY_CNT, RIVAL_MON, RIVAL_CNT, UPD_WEEK, UPD_CNT, STUDY_MON, STUDY_CNT, SEMINAR_MON, SEMINAR_CNT)
				SELECT @SEARCH_MON, @SEARCH_CNT, @DUTY_MON, @DUTY_CNT, @RIVAL_MON, @RIVAL_CNT, @UPD_WEEK, @UPD_CNT, @STUDY_MON, @STUDY_CNT, @SEMINAR_MON, @SEMINAR_CNT
		END
		ELSE
		BEGIN
			INSERT INTO dbo.Risk(ID_MASTER, SEARCH_MON, SEARCH_CNT, DUTY_MON, DUTY_CNT, RIVAL_MON, RIVAL_CNT, UPD_WEEK, UPD_CNT, STUDY_MON, STUDY_CNT, SEMINAR_MON, SEMINAR_CNT, STATUS, UPD_DATE, UPD_USER)
				SELECT ID, SEARCH_MON, SEARCH_CNT, DUTY_MON, DUTY_CNT, RIVAL_MON, RIVAL_CNT, UPD_WEEK, UPD_CNT, STUDY_MON, STUDY_CNT, SEMINAR_MON, SEMINAR_CNT, 2, UPD_DATE, UPD_USER
				FROM dbo.Risk
				WHERE STATUS = 1

			UPDATE dbo.Risk
			SET	SEARCH_MON		=	@SEARCH_MON,
				SEARCH_CNT		=	@SEARCH_CNT,
				DUTY_MON		=	@DUTY_MON,
				DUTY_CNT		=	@DUTY_CNT,
				RIVAL_MON		=	@RIVAL_MON,
				RIVAL_CNT		=	@RIVAL_CNT,
				UPD_WEEK		=	@UPD_WEEK,
				UPD_CNT			=	@UPD_CNT,
				STUDY_MON		=	@STUDY_MON,
				STUDY_CNT		=	@STUDY_CNT,
				SEMINAR_MON		=	@SEMINAR_MON,
				SEMINAR_CNT		=	@SEMINAR_CNT,
				UPD_DATE		=	GETDATE(),
				UPD_USER		=	ORIGINAL_LOGIN()
			WHERE STATUS = 1
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[RISK_SAVE] TO rl_risk_ref;
GO
