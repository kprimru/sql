USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Subhost].[USER_CHECK]
	@LOGIN	NVARCHAR(128),
	@PASS	NVARCHAR(128),
	@IP		NVARCHAR(128) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT b.SH_ID, b.SH_REG
	FROM 
		Subhost.Users a
		INNER JOIN dbo.Subhost b ON a.ID_SUBHOST = b.SH_ID
	WHERE a.NAME = @LOGIN AND a.PASS = @PASS
	
	IF @IP IS NOT NULL
		INSERT INTO Subhost.Session(LGN, IP)
			VALUES(@LOGIN, @IP)
END
