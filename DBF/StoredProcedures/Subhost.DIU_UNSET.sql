USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[DIU_UNSET]
	@SYS	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Subhost.Diu
	SET DIU_ACTIVE = 0,
		DIU_LAST = @DATE
	WHERE DIU_ID_SYSTEM = @SYS
		AND DIU_DISTR = @DISTR
		AND DIU_COMP = @COMP
		AND DIU_ACTIVE = 1
END
