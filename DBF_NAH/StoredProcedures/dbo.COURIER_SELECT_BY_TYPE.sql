USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[COURIER_SELECT_BY_TYPE]
	@TYPE	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT COUR_ID, COUR_NAME
	FROM dbo.CourierTable
	WHERE COUR_ID_TYPE = @TYPE AND COUR_ACTIVE = 1
	ORDER BY COUR_NAME
END

GO
GRANT EXECUTE ON [dbo].[COURIER_SELECT_BY_TYPE] TO rl_courier_r;
GO