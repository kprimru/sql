USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 06.11.2008
��������:	  ������� �������� �����
                �������� ����������
*/

ALTER PROCEDURE [dbo].[SUBHOST_CITY_DELETE]
	@subhostcityid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.SubhostCityTable
	WHERE SC_ID = @subhostcityid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_CITY_DELETE] TO rl_subhost_city_d;
GO