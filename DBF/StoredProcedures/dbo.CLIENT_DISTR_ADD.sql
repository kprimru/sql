USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:         ������� �������
��������:      �������� ����������� �������
*/

CREATE PROCEDURE [dbo].[CLIENT_DISTR_ADD] 
	@clientid INT,
	@distrid INT,
	@registerdate SMALLDATETIME,
	@systemserviceid SMALLINT,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.ClientDistrTable(CD_ID_CLIENT, CD_ID_DISTR, CD_REG_DATE, CD_ID_SERVICE) 
	VALUES (@clientid, @distrid, @registerdate, @systemserviceid)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END







