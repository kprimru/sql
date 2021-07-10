USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[PRICE_DEPEND_DELETE]
	@OLD_PRICE	SMALLINT,
	@OLD_SYS	SMALLINT,
	@OLD_NET	SMALLINT,
	@NEW_PRICE	SMALLINT,
	@NEW_SYS	SMALLINT,
	@NEW_NET	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM Price.PriceDepend
	WHERE ID_OLD_PRICE = @OLD_PRICE
		AND ID_OLD_SYS_TYPE = @OLD_SYS
		AND ID_OLD_NET = @OLD_NET
		AND ID_NEW_PRICE = @NEW_PRICE
		AND ID_NEW_SYS_TYPE = @NEW_SYS
		AND ID_NEW_NET  = @NEW_NET
END

GO
GRANT EXECUTE ON [Price].[PRICE_DEPEND_DELETE] TO rl_price_w;
GO