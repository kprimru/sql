USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ������� ����� � ��������� �����
               �� �����������
*/

ALTER PROCEDURE [dbo].[STREET_DELETE]
	@streetid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.StreetTable WHERE ST_ID = @streetid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[STREET_DELETE] TO rl_street_d;
GO