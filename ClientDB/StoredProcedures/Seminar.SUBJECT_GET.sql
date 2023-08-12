USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[SUBJECT_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[SUBJECT_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Seminar].[SUBJECT_GET]
	@ID	UNIQUEIDENTIFIER
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

		SELECT S.[NAME], S.[NOTE], S.[READER], D.[Demand_IDs]
		FROM [Seminar].[Subject] AS S
		OUTER APPLY
		(
			SELECT [Demand_IDs] = String_Agg(Cast(D.[Demand_Id] AS VarChar(100)), ',')
			FROM [Seminar].[SubjectDemand] AS D
			WHERE D.[Subject_Id] = S.[ID]
		) AS D
		WHERE S.[ID] = @ID;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[SUBJECT_GET] TO rl_seminar_admin;
GO
