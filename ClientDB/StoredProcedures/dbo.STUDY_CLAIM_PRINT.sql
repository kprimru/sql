USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STUDY_CLAIM_PRINT]
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

		SELECT 
			DATE, STUDY_DATE, NOTE,
			REVERSE(STUFF(REVERSE(
				(
					SELECT 
						ISNULL(SURNAME, '') + ' ' + ISNULL(e.NAME, '') + ' ' + ISNULL(PATRON, '') + ' ' +
						'(Дожность: ' + ISNULL(POSITION, 'Нет') + 							
						'; телефон: ' + ISNULL(e.PHONE, '') +  
						'; кол-во обученых: ' + ISNULL(CONVERT(VARCHAR(20), GR_COUNT), '1') + ')' + CHAR(10)
					FROM 
						dbo.ClientStudyClaimPeople e					
					WHERE e.ID_CLAIM = a.ID
					ORDER BY SURNAME, e.NAME, PATRON FOR XML PATH('')
				)
			), 1, 2, '')) AS PEOPLE
		FROM dbo.ClientStudyClaim a
		WHERE a.ID = @ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
