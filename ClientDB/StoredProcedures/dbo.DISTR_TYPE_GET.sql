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

	SELECT DistrTypeName, DistrTypeOrder, DistrTypeFull, DistrTypeBaseCheck, DIstrTypeCode
	FROM dbo.DistrTypeTable
	WHERE DistrTypeID = @ID
END
