USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Common.REFERENCE_LAST_NEW
	@REF	NVARCHAR(60) = NULL,
	@DATE	DATETIME = NULL
AS
	SELECT ReferenceSchema + '.' + ReferenceName AS [Reference], ReferenceLast AS [Last]
	FROM Common.Reference
	WHERE
		(@REF = ReferenceSchema+'.'+ReferenceName OR @REF IS NULL) AND
		(@DATE < ReferenceLast OR @DATE IS NULL)