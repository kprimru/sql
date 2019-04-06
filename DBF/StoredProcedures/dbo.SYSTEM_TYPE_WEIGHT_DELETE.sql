USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_TYPE_WEIGHT_DELETE]
	@STW_ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.SystemTypeWeightTable
	WHERE STW_ID = @STW_ID
END
