USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[BILL_DETAIL_PRINT]
	@ContractNumber		Int,
	@ProviderName		VarChar(100),
	@ContractDate		VarChar(100)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		(SystemNamePrefix + ' ' + ISNULL(SystemPrefix, '') + ' ' + SystemNameStr) AS SystemNameStr,
		SystemPrice, MonthStr, DistrType, SystemOrder, EdIzm, SystemEdPrice, SystemSet, SystemNote
	FROM ContractSystemsTable WITH (NOLOCK)
	WHERE	ContractNumber = @ContractNumber
		AND ProviderName = @ProviderName
		AND ContractDate LIKE @ContractDate
	ORDER BY SystemOrder, SystemPrice;
END
GO
GRANT EXECUTE ON [dbo].[BILL_DETAIL_PRINT] TO DBCount;
GO
