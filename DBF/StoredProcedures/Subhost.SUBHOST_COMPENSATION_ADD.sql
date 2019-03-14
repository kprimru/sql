USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Subhost].[SUBHOST_COMPENSATION_ADD]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@SYS_ID	SMALLINT,
	@SST_ID	SMALLINT,
	@SN_ID	SMALLINT,
	@TT_ID	SMALLINT,
	@DISTR	INT,
	@COMP	TINYINT,
	@COMMENT	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Subhost.SubhostCompensationTable(
			SCP_ID_SUBHOST, SCP_ID_PERIOD, SCP_ID_SYSTEM, SCP_ID_TYPE,
			SCP_ID_NET, SCP_ID_TECH, SCP_DISTR, SCP_COMP, SCP_COMMENT
		)
		VALUES (@SH_ID, @PR_ID, @SYS_ID, @SST_ID, @SN_ID, @TT_ID, @DISTR, @COMP, @COMMENT)
END
