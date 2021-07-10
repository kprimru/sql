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

ALTER PROCEDURE [dbo].[CITY_DELETE]
	@cityid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.CityTable
	WHERE CT_ID = @cityid

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[CITY_DELETE] TO rl_city_d;
GO