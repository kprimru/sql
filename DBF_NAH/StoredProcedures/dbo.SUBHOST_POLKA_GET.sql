USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SUBHOST_POLKA_GET]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT POLKA
	FROM dbo.SubhostPOLKA
	WHERE ID_PERIOD = @PR_ID
		AND ID_SUBHOST = @SH_ID
END

GO
