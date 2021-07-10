USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[PRICE_DEPEND_SET]
	@OLD_PRICE	SMALLINT,
	@OLD_SYS	SMALLINT,
	@OLD_NET	SMALLINT,
	@NEW_PRICE	SMALLINT,
	@NEW_SYS	VARCHAR(MAX),
	@NEW_NET	VARCHAR(MAX),
	@COEF		DECIMAL(8, 4)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Price.PriceDepend
	SET COEF = @COEF
	WHERE ID_OLD_PRICE = @OLD_PRICE
		AND ID_OLD_SYS_TYPE = @OLD_SYS
		AND ID_OLD_NET = @OLD_NET
		AND ID_NEW_PRICE = @NEW_PRICE
		AND ID_NEW_SYS_TYPE IN
			(
				SELECT Item
				FROM dbo.GET_TABLE_FROM_LIST(@NEW_SYS, ',')
			)
		AND ID_NEW_NET IN
			(
				SELECT Item
				FROM dbo.GET_TABLE_FROM_LIST(@NEW_NET, ',')
			)
		AND COEF <> @COEF

	INSERT INTO Price.PriceDepend(ID_OLD_PRICE, ID_NEW_PRICE, ID_OLD_SYS_TYPE, ID_NEW_SYS_TYPE, ID_OLD_NET, ID_NEW_NET, COEF)
		SELECT @OLD_PRICE, @NEW_PRICE, @OLD_SYS, a.Item, @OLD_NET, b.Item, @COEF
		FROM
			dbo.GET_TABLE_FROM_LIST(@NEW_SYS, ',') AS a
			CROSS JOIN dbo.GET_TABLE_FROM_LIST(@NEW_NET, ',') AS b
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Price.PriceDepend
				WHERE ID_OLD_PRICE = @OLD_PRICE
					AND ID_NEW_PRICE = @NEW_PRICE
					AND ID_OLD_SYS_TYPE = @OLD_SYS
					AND ID_NEW_SYS_TYPE = a.Item
					AND ID_OLD_NET = @OLD_NET
					AND ID_NEW_NET = b.Item
			)
END

GO
GRANT EXECUTE ON [Price].[PRICE_DEPEND_SET] TO rl_price_w;
GO