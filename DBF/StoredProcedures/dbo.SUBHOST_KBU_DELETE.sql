USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SUBHOST_KBU_DELETE]
	@SK_ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.SubhostKBUTable 
	WHERE SK_ID = @SK_ID
END
