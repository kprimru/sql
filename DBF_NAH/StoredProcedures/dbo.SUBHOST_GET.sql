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

ALTER PROCEDURE [dbo].[SUBHOST_GET]
	@subhostid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT
			SH_ID, SH_FULL_NAME, SH_SHORT_NAME, SH_SUBHOST, SH_LST_NAME,
			SH_REG, SH_CALC_STUDY, SH_CALC_SYSTEM, SH_ORDER, SH_CALC, SH_PENALTY, SH_PERIODICITY, SH_ACTIVE
	FROM
		dbo.SubhostTable a
	WHERE SH_ID = @subhostid

	SET NOCOUNT OFF
END












GO
GRANT EXECUTE ON [dbo].[SUBHOST_GET] TO rl_subhost_r;
GO