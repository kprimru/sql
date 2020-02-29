USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONTACT_ARCH]
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

		INSERT INTO dbo.ClientContact(ID_MASTER, ID_CLIENT, DATE, PERSONAL, SURNAME, NAME, PATRON, POSITION, ID_TYPE, CATEGORY, NOTE, PROBLEM, STATUS, UPD_DATE, UPD_USER)
			SELECT @ID, ID_CLIENT, DATE, PERSONAL, SURNAME, NAME, PATRON, POSITION, ID_TYPE, CATEGORY, NOTE, PROBLEM, 2, UPD_DATE, UPD_USER
			FROM dbo.ClientContact
			WHERE ID = @ID
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
