USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[TO_PERSONAL_DEFAULT]
	@ID	INT
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

		DECLARE @RP	INT
		DECLARE @RP_NAME VARCHAR(100)

		SELECT TOP 1 @RP = RP_ID, @RP_NAME = RP_NAME
		FROM dbo.ReportPositionTable
		WHERE RP_ACTIVE = 1
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.TOPersonalTable
					WHERE TP_ID_RP = RP_ID
						AND TP_ID_TO = @ID
				)
		ORDER BY RP_ID

		SELECT
			'' AS TP_SURNAME, '' AS TP_NAME, '' AS TP_OTCH, '8(423)' AS TP_PHONE,
			@RP AS RP_ID, @RP_NAME AS RP_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[TO_PERSONAL_DEFAULT] TO rl_to_personal_r;
GO
