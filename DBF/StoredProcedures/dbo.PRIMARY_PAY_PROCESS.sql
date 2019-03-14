USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	

/*
�����:			������� �������
���� ��������:	02.02.2009
��������:		������ �������� (���� ���� - 
				������������, ���� ��� - ��������)
*/

CREATE PROCEDURE [dbo].[PRIMARY_PAY_PROCESS]
	@ppid INT,
	@distrid INT,
	@paydate SMALLDATETIME,
	@price MONEY,
	@taxprice MONEY,
	@totalprice MONEY,
	@doc VARCHAR(50),
	@taxid SMALLINT = NULL,
	@comment VARCHAR(250) = NULL,
	@org SMALLINT = NULL,
    @returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	-- �������� id ������. 20.04.2009, ������.

	IF @ppid IS NULL
	  BEGIN
		INSERT INTO dbo.PrimaryPayTable(PRP_ID_CLIENT, PRP_ID_DISTR, PRP_DATE, PRP_PRICE, PRP_DOC,
									PRP_TAX_PRICE, PRP_TOTAL_PRICE, PRP_ID_TAX, 
									PRP_COMMENT, PRP_ID_ORG) 
			SELECT 
				CD_ID_CLIENT, @distrid, @paydate, @price, @doc, @taxprice, 
				@totalprice, @taxid, @comment, @org
			FROM dbo.ClientDistrTable
			WHERE CD_ID_DISTR = @distrid		

		IF @returnvalue = 1
		  SELECT SCOPE_IDENTITY() AS NEW_IDEN  
	  END
	ELSE
	  BEGIN
		UPDATE dbo.PrimaryPayTable
		SET PRP_DATE = @paydate,
			PRP_ID_DISTR = @distrid,
			PRP_PRICE = @price,
			PRP_TAX_PRICE = @taxprice,
			PRP_TOTAL_PRICE = @totalprice,
			PRP_DOC = @doc,
			PRP_ID_TAX = @taxid,
			PRP_COMMENT = @comment,
			PRP_ID_ORG = @org
		WHERE PRP_ID = @ppid 
	  END

	SET NOCOUNT OFF
END
