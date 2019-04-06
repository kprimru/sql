USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
���� ��������: 21.11.2008
��������:	  ������� ��� �������, ������� 
               �� ������������ � ������������ 
               ���������� ���� �� ��������� 
               ������
*/

CREATE PROCEDURE [dbo].[PRICE_SYSTEM_LIST_GET]  
	@pricetypeid SMALLINT, 
	@periodid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	SELECT '�������' AS IS_SYS, SYS_ID, SYS_SHORT_NAME, HST_NAME 
	FROM dbo.SystemTable a LEFT OUTER JOIN
		 dbo.HostTable d ON a.SYS_ID_HOST = d.HST_ID
	WHERE SYS_ID NOT IN
		 (
		   SELECT SYS_ID 
		   FROM dbo.SystemTable c INNER JOIN
				dbo.PriceSystemTable b ON b.PS_ID_SYSTEM = c.SYS_ID
		   WHERE PS_ID_TYPE = @pricetypeid AND 
				 PS_ID_PERIOD = @periodid AND 
				 c.SYS_ID = a.SYS_ID
		 ) AND SYS_ACTIVE = 1

	UNION

	SELECT '���.������' AS IS_SYS, PGD_ID, PGD_NAME, '-'
	FROM dbo.PriceGoodTable
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.PriceSystemTable
			WHERE PS_ID_TYPE = @pricetypeid
				AND PS_ID_PERIOD = @periodid	
				AND PS_ID_PGD = PGD_ID
		)

	SET NOCOUNT OFF
END
