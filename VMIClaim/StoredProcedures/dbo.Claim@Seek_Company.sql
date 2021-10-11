USE [VMIClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Claim@Seek?Company]
    @Id     UniqueIdentifier
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @Phone  VarChar(100),
        @Email  VarChar(100);

    SELECT
        @Phone = PHONE,
        @Email = EMAIL
    FROM dbo.Claim
    WHERE ID = @Id;

    SET @Phone = Replace(@Phone, '+7', '8')

    EXEC [SaleDB].[Client.Company@Seek-By-Phone-And-Email]
        @Phone = @Phone,
        @Email = @Email;
END
GO
GRANT EXECUTE ON [dbo].[Claim@Seek?Company] TO rl_write;
GO