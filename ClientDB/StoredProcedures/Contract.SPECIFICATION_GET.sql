USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[SPECIFICATION_GET]
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
			NUM, NAME, NOTE, FILE_PATH,
			('<LIST>' + 
				(
					SELECT '{' + CONVERT(NVARCHAR(64), ID_FORM) + '}' AS ITEM
					FROM Contract.SpecificationForms z
					WHERE z.ID_SPECIFICATION = a.ID
					FOR XML PATH('')
				) 
			+ '</LIST>') AS FORM_LIST
		FROM Contract.Specification a
		WHERE ID = @ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
