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

CREATE PROCEDURE [dbo].[REFERENCE_GET] 
	@refname VARCHAR(50) = NULL  
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		REF_ID, REF_SCHEMA, REF_NAME, REF_TITLE, REF_FIELD_ID, REF_FIELD_NAME, 
		REF_READ_ONLY 
	FROM dbo.ReferenceTable 
	WHERE REF_NAME = @refname 		

	SET NOCOUNT OFF
END





