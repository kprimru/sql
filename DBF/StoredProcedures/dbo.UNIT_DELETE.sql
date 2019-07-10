USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
���� ��������: 18.12.2008
��������:	  ������� ��������������� ������� 
               � ��������� ����� �� �����������
*/

CREATE PROCEDURE [dbo].[UNIT_DELETE] 
	@unitid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.UnitTable 
	WHERE UN_ID = @unitid

	SET NOCOUNT OFF
END
