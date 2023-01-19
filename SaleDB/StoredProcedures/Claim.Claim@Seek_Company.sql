USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[Claim@Seek?Company]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[Claim@Seek?Company]  AS SELECT 1')
GO
ALTER PROCEDURE [Claim].[Claim@Seek?Company]
    @Id     Int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @Phone  VarChar(100),
        @Email  VarChar(100);

    SELECT
        @Phone = PHONE,
        @Email = EMAIL
    FROM [Claim].[Claims]
    WHERE [Id] = @Id;

    SET @Email = NullIf(Ltrim(Rtrim(@Email)), '');
    SET @Phone = NullIf(Ltrim(Rtrim(@Phone)), '');
    SET @Phone = Replace(@Phone, '+7', '8')

    EXEC [Client].[Company@Seek-By-Phone-And-Email]
        @Phone = @Phone,
        @Email = @Email;
END
GO
GRANT EXECUTE ON [Claim].[Claim@Seek?Company] TO rl_claim_set_company;
GO
