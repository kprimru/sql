USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[SERVICE_SALARY_STUDY_IMPORT]
	@ID			UNIQUEIDENTIFIER,
	@MONTH		UNIQUEIDENTIFIER,
	@SERVICE	INT
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

		DECLARE @START	SMALLDATETIME
		DECLARE @FINISH	SMALLDATETIME

		SELECT @START = START_REPORT, @FINISH = FINISH_REPORT
		FROM Common.Period
		WHERE ID = @MONTH

		INSERT INTO Salary.ServiceStudy(ID_SALARY, ID_CLIENT, DATE)
			SELECT DISTINCT @ID, ID_CLIENT, DATE
			FROM
				dbo.ClientStudy a
				INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
			WHERE a.STATUS = 1
			    AND a.AGREEMENT = 1
				AND DATE BETWEEN @START AND @FINISH
				AND dbo.ClientServiceDate(ClientID, DATE) = @SERVICE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Salary].[SERVICE_SALARY_STUDY_IMPORT] TO rl_salary;
GO