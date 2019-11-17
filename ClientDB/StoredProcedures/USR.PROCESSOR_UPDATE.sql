USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[PROCESSOR_UPDATE]
	@ID		INT,
	@NAME	VARCHAR(100),
	@FREQ_S	VARCHAR(50),
	@FREQ	DECIMAL(8, 4),
	@CORE	SMALLINT,
	@PF_ID	INT	
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE USR.Processor
	SET	PRC_NAME = @NAME,
		PRC_FREQ_S = @FREQ_S,
		PRC_FREQ = @FREQ,
		PRC_CORE = @CORE,
		PRC_ID_FAMILY = @PF_ID
	WHERE PRC_ID = @ID
END