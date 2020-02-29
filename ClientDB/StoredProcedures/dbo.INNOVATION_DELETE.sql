USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INNOVATION_DELETE]
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

		DELETE 
		FROM dbo.ClientInnovationControl
		WHERE ID_PERSONAL IN
			(
				SELECT ID
				FROM dbo.ClientInnovationPersonal
				WHERE ID_INNOVATION IN
					(
						SELECT ID
						FROM dbo.ClientInnovation
						WHERE ID_INNOVATION = @ID
					)
			)
		
		DELETE
		FROM dbo.ClientInnovationPersonal
		WHERE ID_INNOVATION IN
			(
				SELECT ID
				FROM dbo.ClientInnovation
				WHERE ID_INNOVATION = @ID
			)
			
		DELETE
		FROM dbo.ClientInnovation
		WHERE ID_INNOVATION = @ID
		
		DELETE
		FROM dbo.Innovation
		WHERE ID = @ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
