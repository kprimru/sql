USE [VMIClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Claim@Select?Company]
    @Filter     VarChar(255)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    EXEC [SaleDB].[Client.COMPANY_SELECT2]
        @SEARCH = @Filter;
END
GO
GRANT EXECUTE ON [dbo].[Claim@Select?Company] TO rl_write;
GO