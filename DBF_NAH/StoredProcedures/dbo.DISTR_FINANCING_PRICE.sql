USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISTR_FINANCING_PRICE]
	@DF_ID	INT,
	@PRICE	MONEY
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.DistrFinancingTable
	SET DF_FIXED_PRICE = @PRICE
	WHERE DF_ID = @DF_ID
END

GO
GRANT EXECUTE ON [dbo].[DISTR_FINANCING_PRICE] TO rl_distr_financing_w;
GO