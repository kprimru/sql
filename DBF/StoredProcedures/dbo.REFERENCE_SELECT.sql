USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  Выбрать данные о спарвочнике, либо список всех справочников
*/

CREATE PROCEDURE [dbo].[REFERENCE_SELECT] 
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON
	
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
				REF_ID, REF_NAME, REF_TITLE, REF_FIELD_ID, REF_FIELD_NAME, 
				REF_READ_ONLY 
		FROM dbo.ReferenceTable 
		ORDER BY REF_TITLE
	
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
