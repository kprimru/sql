USE [VMIClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Claim@Get?Company Info]
    @Id     UniqueIdentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Company_Id
    FROM dbo.Claim
    WHERE ID = @Id;
END
GO
GRANT EXECUTE ON [dbo].[Claim@Get?Company Info] TO rl_write;
GO