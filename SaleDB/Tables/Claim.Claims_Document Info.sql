USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[Claims:Document Info]
(
        [Id]               Int             Identity(1,1)   NOT NULL,
        [Claim_Id]         Int                                 NULL,
        [CreateDateTime]   DateTime                            NULL,
        [FIO]              NVarChar(512)                       NULL,
        [CityName]         NVarChar(512)                       NULL,
        [EMail]            NVarChar(512)                       NULL,
        [Phone]            NVarChar(512)                       NULL,
        [Actions]          NVarChar(Max)                       NULL,
        CONSTRAINT [PK_Claim.Claims:Document Info] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_Claim.Claims:Document Info(Claim_Id)_Claim.Claims(Id)] FOREIGN KEY  ([Claim_Id]) REFERENCES [Claim].[Claims] ([Id])
);GO
