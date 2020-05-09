USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ODD_DIN_SAVE]
	@Host_Id	SmallInt,
	@Distr		Int,
	@Comp		TinyInt,
	@Company_Id	UniqueIdentifier
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Client.CompanyOdd(Company_Id, Host_Id, Distr, Comp)
	VALUES(@Company_Id, @Host_Id, @Distr, @Comp)
END
GO
GRANT EXECUTE ON [dbo].[ODD_DIN_SAVE] TO rl_odd_din_r;
GO