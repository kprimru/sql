USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[Claims:Companies]
(
        [Claim_Id]     Int                   NOT NULL,
        [Company_Id]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Claim.Claims:Companies] PRIMARY KEY CLUSTERED ([Claim_Id],[Company_Id]),
        CONSTRAINT [FK_Claim.Claims:Companies(Claim_Id)_Claim.Claims(Id)] FOREIGN KEY  ([Claim_Id]) REFERENCES [Claim].[Claims] ([Id]),
        CONSTRAINT [FK_Claim.Claims:Companies(Company_Id)_Claim.Company(ID)] FOREIGN KEY  ([Company_Id]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Claim.Claims:Companies(Company_Id)+(Claim_Id)] ON [Claim].[Claims:Companies] ([Company_Id] ASC) INCLUDE ([Claim_Id]);
GO
