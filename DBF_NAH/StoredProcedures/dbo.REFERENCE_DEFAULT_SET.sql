USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[REFERENCE_DEFAULT_SET]
	@refname VARCHAR(100),
	@dataid INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @refid INT

	SELECT @refid = REF_ID
	FROM dbo.ReferenceTable
	WHERE REF_NAME = @refname

	IF @refid IS NULL
		RETURN

	INSERT INTO dbo.ReferenceDefaultTable (RD_ID_REF, RD_USER, RD_VALUE)
		SELECT @refid, USER_NAME(), @dataid

END

GO
