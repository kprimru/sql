USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[DISTR_INCOME_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM Distr.DistrIncome WHERE ID = @ID
END
GO
GRANT EXECUTE ON [Distr].[DISTR_INCOME_DELETE] TO rl_distr_income_w;
GO
