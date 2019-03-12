USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SUBHOST_COMPLECT_SET]
	@HOST	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@SH_ID	UNIQUEIDENTIFIER,
	@REG	BIT,
	@USR	BIT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.SubhostComplect
	SET SC_ID_SUBHOST	=	@SH_ID,
		SC_REG			=	@REG,
		SC_USR			=	@USR
	WHERE SC_ID_HOST	=	@HOST
		AND SC_DISTR	=	@DISTR
		AND SC_COMP		=	@COMP
		
	IF @@ROWCOUNT = 0
		INSERT INTO dbo.SubhostComplect(SC_ID_SUBHOST, SC_ID_HOST, SC_DISTR, SC_COMP, SC_REG, SC_USR)
			VALUES(@SH_ID, @HOST, @DISTR, @COMP, @REG, @USR)
END
