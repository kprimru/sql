USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[Claims]
(
        [Id]               Int                Identity(1,1)   NOT NULL,
        [Type_id]          TinyInt                            NOT NULL,
        [Number]           Int                                NOT NULL,
        [CreateDateTime]   DateTime                           NOT NULL,
        [FIO]              NVarChar(512)                          NULL,
        [ClientName]       NVarChar(512)                          NULL,
        [CityName]         NVarChar(512)                          NULL,
        [EMail]            NVarChar(512)                          NULL,
        [Phone]            NVarChar(512)                          NULL,
        [Special]          NVarChar(Max)                          NULL,
        [Actions]          NVarChar(Max)                          NULL,
        [PageURL]          NVarChar(512)                          NULL,
        [PageTitle]        NVarChar(512)                          NULL,
        [Status_Id]        TinyInt                            NOT NULL,
        [Distr]            NVarChar(512)                          NULL,
        [Personal_Id]      UniqueIdentifier                       NULL,
        [Company_Id]       UniqueIdentifier                       NULL,
        [GUId]             UniqueIdentifier                       NULL,
        [Section]          NVarChar(512)                          NULL,
        CONSTRAINT [PK_Claim.Claims] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE NONCLUSTERED INDEX [IX_Claim.Claims(Company_Id)] ON [Claim].[Claims] ([Company_Id] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_Claim.Claims(Number,Type_id,CreateDateTime)] ON [Claim].[Claims] ([Number] ASC, [Type_id] ASC, [CreateDateTime] ASC);
GO
