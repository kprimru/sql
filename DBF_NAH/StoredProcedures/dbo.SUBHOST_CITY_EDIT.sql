USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[SUBHOST_CITY_EDIT]
	@subhostcityid INT,
	@subhostid SMALLINT,
	@cityid SMALLINT,
	@marketareaid SMALLINT,
	@active BIT
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.SubhostCityTable
	SET
		SC_ID_SUBHOST = @subhostid,
		SC_ID_CITY = @cityid,
	    SC_ID_MARKET_AREA = @marketareaid,
		SC_ACTIVE = @active
	WHERE SC_ID = @subhostcityid

	SET NOCOUNT OFF
END








GO
GRANT EXECUTE ON [dbo].[SUBHOST_CITY_EDIT] TO rl_subhost_city_w;
GO