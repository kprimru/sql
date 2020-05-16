USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[DEPO_NUMBER_NEW_GET]
AS
BEGIN
	SELECT MIN(DEPO_NUM) AS DEPO_NUM
	FROM Client.DepoNumbers
	WHERE	STATUS = 1 AND
			DEPO_NUM > 6229 -- ��� ��� ���� ����� ������, ����� ���� �� 6000 �������
END

GO
GRANT EXECUTE ON [Client].[DEPO_NUMBER_NEW_GET] TO rl_depo_info_r;
GO