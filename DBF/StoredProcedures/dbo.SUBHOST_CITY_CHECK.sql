USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 06.11.2008
��������:	  ��������� ������������ �������� 
               � ������
*/

CREATE PROCEDURE [dbo].[SUBHOST_CITY_CHECK] 
	@subhostid SMALLINT,
	@cityid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	SELECT SC_ID
	FROM dbo.SubhostCityTable
	WHERE SC_ID_SUBHOST = @subhostid AND SC_ID_CITY = @cityid

	SET NOCOUNT OFF
END