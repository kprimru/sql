USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[REG_NODE_SUBHOST_DELETE]
	@RNS_ID BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE	
	FROM Subhost.RegNodeSubhostTable
	WHERE RNS_ID = @RNS_ID
END
