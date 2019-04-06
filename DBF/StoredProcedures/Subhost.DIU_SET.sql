USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[DIU_SET]
	@SYS	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@SH		INT,
	@DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS
		(
			SELECT *
			FROM Subhost.Diu
			WHERE DIU_ID_SYSTEM = @SYS
				AND DIU_DISTR = @DISTR
				AND DIU_COMP = @COMP
				AND DIU_ACTIVE = 1
		)
		UPDATE Subhost.Diu
		SET DIU_ACTIVE = 0,
			DIU_LAST = @DATE
		WHERE DIU_ID_SYSTEM = @SYS
			AND DIU_DISTR = @DISTR
			AND DIU_COMP = @COMP
			AND DIU_ACTIVE = 1

	INSERT INTO Subhost.Diu(DIU_ID_SYSTEM, DIU_DISTR, DIU_COMP, DIU_ID_SUBHOST, DIU_DATE, DIU_ACTIVE)
		VALUES(@SYS, @DISTR, @COMP, @SH, @DATE, 1)
END
