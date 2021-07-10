USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:
*/

ALTER PROCEDURE [dbo].[SUBHOST_CITY_ADD]
	@subhostid SMALLINT,
	@cityid SMALLINT,
	@marketareaid SMALLINT,
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.SubhostCityTable(SC_ID_SUBHOST, SC_ID_CITY, SC_ID_MARKET_AREA, SC_ACTIVE)
	VALUES (@subhostid, @cityid, @marketareaid, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END








GO
GRANT EXECUTE ON [dbo].[SUBHOST_CITY_ADD] TO rl_subhost_city_w;
GO