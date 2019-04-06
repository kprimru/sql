USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DISTR_TYPE_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		DistrTypeName, DistrTypeShortName, DistrTypeOrder,
		DistrTypeFull, DIstrTypeBaseCheck
	FROM dbo.DistrTypeTable
	WHERE DistrTypeID = @ID
END